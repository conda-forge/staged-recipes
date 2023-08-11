import React, { useEffect, useState, useContext } from 'react';
import { useUpdateRunDetails } from '../../../apollo/mutations';

import { ButtonTimeoutContext } from '../../../utils/button-timeout-context';

import Button from '../../ui/button';
import Modal from '../../ui/modal';
import Input from '../../ui/input';

import '../../settings-modal/settings-modal.css';
import './run-details-modal.css';

const RunDetailsModal = ({
  runMetadataToEdit,
  setShowRunDetailsModal,
  theme,
  visible,
}) => {
  const [valuesToUpdate, setValuesToUpdate] = useState({});
  const { updateRunDetails, error, reset } = useUpdateRunDetails();
  const {
    handleClick,
    hasNotInteracted,
    isSuccessful,
    setHasNotInteracted,
    setIsSuccessful,
    showModal,
  } = useContext(ButtonTimeoutContext);

  const onApplyChanges = () => {
    updateRunDetails({
      runId: runMetadataToEdit.id,
      runInput: { notes: valuesToUpdate.notes, title: valuesToUpdate.title },
    });

    handleClick();

    if (!error) {
      setIsSuccessful(true);
    }
  };

  const onChange = (key, value) => {
    setValuesToUpdate(
      Object.assign({}, valuesToUpdate, {
        [key]: value,
      })
    );
    setHasNotInteracted(false);
  };

  // only if the component is visible first, then apply isSuccessful to show or hide modal
  useEffect(() => {
    if (visible && isSuccessful) {
      setShowRunDetailsModal(showModal);
    }
  }, [showModal, setShowRunDetailsModal, isSuccessful, visible]);

  useEffect(() => {
    setValuesToUpdate({
      notes: runMetadataToEdit?.notes,
      title: runMetadataToEdit?.title,
    });
  }, [runMetadataToEdit]);

  useEffect(() => {
    /**
     * If there's a GraphQL error when trying to update the title/notes,
     * reset the mutation when the modal closes so the error doesn't appear
     * the next time the modal opens.
     */
    reset();
  }, [runMetadataToEdit, visible, setHasNotInteracted, reset]);

  return (
    <div className="pipeline-settings-modal pipeline-settings-modal--experiment-tracking">
      <Modal
        closeModal={() => setShowRunDetailsModal(false)}
        theme={theme}
        title="Edit run details"
        visible={visible}
      >
        <div className="pipeline-settings-modal__content pipeline-settings-modal__content--short">
          <div className="pipeline-settings-modal__header">
            <div className="pipeline-settings-modal__name">Run name</div>
          </div>
          <Input
            defaultValue={runMetadataToEdit?.title}
            onChange={(value) => onChange('title', value)}
            resetValueTrigger={visible}
            size="large"
          />
        </div>
        <div className="pipeline-settings-modal__content pipeline-settings-modal__content--short">
          <div className="pipeline-settings-modal__header">
            <div className="pipeline-settings-modal__name">Notes</div>
          </div>
          <Input
            characterLimit={500}
            defaultValue={runMetadataToEdit?.notes || ''}
            onChange={(value) => onChange('notes', value)}
            placeholder="Add here"
            resetValueTrigger={visible}
            size="small"
          />
        </div>
        <div className="run-details-modal-button-wrapper">
          <Button
            mode="secondary"
            onClick={() => setShowRunDetailsModal(false)}
            size="small"
          >
            Cancel
          </Button>
          <Button
            dataTest={'Apply changes and close in Run Details Modal'}
            disabled={hasNotInteracted}
            onClick={onApplyChanges}
            mode={isSuccessful ? 'success' : 'primary'}
            size="small"
          >
            {isSuccessful ? (
              <>
                Changes applied <span className="success-check-mark">✅</span>
              </>
            ) : (
              'Apply changes and close'
            )}
          </Button>
        </div>
        {error ? (
          <div className="run-details-modal-error-wrapper">
            <p>Couldn't update run details. Please try again later.</p>
          </div>
        ) : null}
      </Modal>
    </div>
  );
};

export default RunDetailsModal;
