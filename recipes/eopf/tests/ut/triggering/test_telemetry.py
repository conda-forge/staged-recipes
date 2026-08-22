#
# Copyright (C) 2026 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
from __future__ import annotations

from typing import Any
from unittest import mock

import pytest

from eopf import EOConfiguration
from eopf.triggering import telemetry as telemetry_module
from eopf.triggering.telemetry import OpenTelemetryWorkflowCallback
from eopf.triggering.workflow_callbacks import (
    WORKFLOW_EVENT_AFTER_UNIT,
    WORKFLOW_EVENT_AFTER_OUTPUT_WRITE_FLUSH,
    WORKFLOW_EVENT_AFTER_OUTPUT_WRITE_SUBMIT,
    WORKFLOW_EVENT_BEFORE_UNIT,
    WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_FLUSH,
    WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_SUBMIT,
    WORKFLOW_EVENT_ON_OUTPUT_WRITE_FLUSH_ERROR,
    WORKFLOW_EVENT_ON_OUTPUT_WRITE_SUBMIT_ERROR,
    WORKFLOW_EVENT_ON_UNIT_ERROR,
    WORKFLOW_EVENT_SETUP,
    WORKFLOW_EVENT_TEARDOWN,
    WorkflowCallbackContext,
    build_default_workflow_callbacks,
)


class FakeSpan:
    def __init__(self, name: str, attributes: dict[str, Any] | None = None) -> None:
        self.name = name
        self.attributes = dict(attributes or {})
        self.exceptions: list[BaseException] = []
        self.ended = False

    def set_attribute(self, key: str, value: Any) -> None:
        self.attributes[key] = value

    def record_exception(self, exception: BaseException) -> None:
        self.exceptions.append(exception)


class FakeSpanContext:
    def __init__(self, span: FakeSpan) -> None:
        self.span = span

    def __enter__(self) -> FakeSpan:
        return self.span

    def __exit__(self, *_args: Any) -> None:
        self.span.ended = True


class FakeTracer:
    def __init__(self) -> None:
        self.spans: list[FakeSpan] = []

    def start_as_current_span(self, name: str, attributes: dict[str, Any] | None = None) -> FakeSpanContext:
        span = FakeSpan(name, attributes)
        self.spans.append(span)
        return FakeSpanContext(span)


@pytest.fixture(autouse=True)
def reset_opentelemetry_config() -> None:
    EOConfiguration()["triggering__opentelemetry_enabled"] = False
    EOConfiguration()["triggering__opentelemetry_configure_sdk"] = True
    telemetry_module._TRACER = None
    telemetry_module._SDK_CONFIGURED = False


@pytest.mark.unit
def test_default_workflow_callbacks_exclude_opentelemetry_when_disabled() -> None:
    callbacks = build_default_workflow_callbacks()

    assert all(not isinstance(callback, OpenTelemetryWorkflowCallback) for callback in callbacks)


@pytest.mark.unit
def test_default_workflow_callbacks_exclude_opentelemetry_when_package_is_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    EOConfiguration()["triggering__opentelemetry_enabled"] = True
    monkeypatch.setattr(telemetry_module, "module_available", lambda _module_name: False)

    callbacks = build_default_workflow_callbacks()

    assert all(not isinstance(callback, OpenTelemetryWorkflowCallback) for callback in callbacks)


@pytest.mark.unit
def test_default_workflow_callbacks_include_opentelemetry_when_enabled(monkeypatch: pytest.MonkeyPatch) -> None:
    EOConfiguration()["triggering__opentelemetry_enabled"] = True
    monkeypatch.setattr(telemetry_module, "_get_tracer", FakeTracer)

    callbacks = build_default_workflow_callbacks()

    assert any(isinstance(callback, OpenTelemetryWorkflowCallback) for callback in callbacks)


@pytest.mark.unit
def test_opentelemetry_workflow_callback_records_workflow_and_unit_spans() -> None:
    tracer = FakeTracer()
    callback = OpenTelemetryWorkflowCallback(tracer=tracer)
    processing_unit = mock.Mock(identifier="processor")
    unit = mock.Mock(identifier="unit", processing_unit=processing_unit)
    plan = mock.Mock(workflow=[unit])

    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_SETUP, plan=plan, metadata={"workflow_id": "run-123"}))
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_BEFORE_UNIT,
            plan=plan,
            unit=unit,
            metadata={"unit_index": 0},
        ),
    )
    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_AFTER_UNIT, plan=plan, unit=unit))
    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_TEARDOWN, plan=plan, metadata={"error_count": 0}))

    workflow_span, unit_span = tracer.spans
    assert workflow_span.name == "eopf.triggering.workflow"
    assert workflow_span.attributes["eopf.workflow.units"] == 1
    assert workflow_span.attributes["eopf.workflow.id"] == "run-123"
    assert workflow_span.attributes["eopf.workflow.error_count"] == 0
    assert workflow_span.ended
    assert unit_span.name == "eopf.triggering.unit"
    assert unit_span.attributes["eopf.workflow.unit"] == "unit"
    assert unit_span.attributes["eopf.processing_unit"] == "processor"
    assert unit_span.attributes["eopf.workflow.unit_index"] == 0
    assert unit_span.ended


@pytest.mark.unit
def test_opentelemetry_workflow_callback_records_unit_error() -> None:
    tracer = FakeTracer()
    callback = OpenTelemetryWorkflowCallback(tracer=tracer)
    processing_unit = mock.Mock(identifier="processor")
    unit = mock.Mock(identifier="unit", processing_unit=processing_unit)
    plan = mock.Mock(workflow=[unit])
    error = RuntimeError("failed")

    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_SETUP, plan=plan))
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_BEFORE_UNIT,
            plan=plan,
            unit=unit,
            metadata={"unit_index": 0},
        ),
    )
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_ON_UNIT_ERROR,
            plan=plan,
            unit=unit,
            metadata={
                "exception": error,
                "exception_type": "RuntimeError",
                "exception_message": "failed",
            },
        ),
    )
    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_TEARDOWN, plan=plan, metadata={"error_count": 1}))

    unit_span = tracer.spans[1]
    assert unit_span.exceptions == [error]
    assert unit_span.attributes["eopf.workflow.error_type"] == "RuntimeError"
    assert unit_span.attributes["eopf.workflow.error_message"] == "failed"
    assert unit_span.ended


@pytest.mark.unit
def test_opentelemetry_workflow_callback_records_workflow_error() -> None:
    tracer = FakeTracer()
    callback = OpenTelemetryWorkflowCallback(tracer=tracer)
    plan = mock.Mock(workflow=[])
    error = RuntimeError("teardown failed")

    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_SETUP, plan=plan))
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_TEARDOWN,
            plan=plan,
            metadata={
                "error_count": 1,
                "exception": error,
                "exception_type": "RuntimeError",
                "exception_message": "teardown failed",
            },
        ),
    )

    workflow_span = tracer.spans[0]
    assert workflow_span.exceptions == [error]
    assert workflow_span.attributes["eopf.workflow.error_count"] == 1
    assert workflow_span.attributes["eopf.workflow.error_type"] == "RuntimeError"
    assert workflow_span.attributes["eopf.workflow.error_message"] == "teardown failed"
    assert workflow_span.ended


@pytest.mark.unit
def test_opentelemetry_workflow_callback_records_output_write_submit_and_flush_spans() -> None:
    tracer = FakeTracer()
    callback = OpenTelemetryWorkflowCallback(tracer=tracer)
    unit = mock.Mock(identifier="unit")
    plan = mock.Mock(workflow=[unit])

    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_SUBMIT,
            plan=plan,
            unit=unit,
            metadata={
                "output_id": "output",
                "output_name": "out",
                "output_path": "output.zarr",
                "engine": "cpm_zarr",
            },
        ),
    )
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_AFTER_OUTPUT_WRITE_SUBMIT,
            plan=plan,
            unit=unit,
            metadata={
                "output_id": "output",
                "output_name": "out",
                "product_path": "resolved-output.zarr",
                "engine": "cpm_zarr",
                "write_is_delayed": True,
            },
        ),
    )
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_FLUSH,
            plan=plan,
            metadata={
                "output_id": "output",
                "product_path": "resolved-output.zarr",
                "engine": "cpm_zarr",
                "write_is_delayed": True,
                "action": "Finished",
            },
        ),
    )
    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_AFTER_OUTPUT_WRITE_FLUSH, plan=plan))

    submit_span, flush_span = tracer.spans
    assert submit_span.name == "eopf.triggering.output_write.submit"
    assert submit_span.attributes["eopf.output.id"] == "output"
    assert submit_span.attributes["eopf.output.name"] == "out"
    assert submit_span.attributes["eopf.output.path"] == "resolved-output.zarr"
    assert submit_span.attributes["eopf.output.write_is_delayed"]
    assert submit_span.attributes["eopf.workflow.unit"] == "unit"
    assert submit_span.ended
    assert flush_span.name == "eopf.triggering.output_write.flush"
    assert flush_span.attributes["eopf.output.path"] == "resolved-output.zarr"
    assert flush_span.attributes["eopf.output.write_action"] == "Finished"
    assert flush_span.ended


@pytest.mark.unit
def test_opentelemetry_workflow_callback_records_output_write_errors() -> None:
    tracer = FakeTracer()
    callback = OpenTelemetryWorkflowCallback(tracer=tracer)
    plan = mock.Mock(workflow=[])
    submit_error = RuntimeError("submit failed")
    flush_error = RuntimeError("flush failed")

    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_SUBMIT, plan=plan))
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_ON_OUTPUT_WRITE_SUBMIT_ERROR,
            plan=plan,
            metadata={
                "exception": submit_error,
                "exception_type": "RuntimeError",
                "exception_message": "submit failed",
            },
        ),
    )
    callback(WorkflowCallbackContext(event=WORKFLOW_EVENT_BEFORE_OUTPUT_WRITE_FLUSH, plan=plan))
    callback(
        WorkflowCallbackContext(
            event=WORKFLOW_EVENT_ON_OUTPUT_WRITE_FLUSH_ERROR,
            plan=plan,
            metadata={
                "exception": flush_error,
                "exception_type": "RuntimeError",
                "exception_message": "flush failed",
            },
        ),
    )

    submit_span, flush_span = tracer.spans
    assert submit_span.exceptions == [submit_error]
    assert submit_span.attributes["eopf.output.write_error_message"] == "submit failed"
    assert submit_span.ended
    assert flush_span.exceptions == [flush_error]
    assert flush_span.attributes["eopf.output.write_error_message"] == "flush failed"
    assert flush_span.ended
