import { Component, OnInit } from "@angular/core";
import { ApiService } from "./api.service";
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ValidationErrors,
  Validators,
} from "@angular/forms";
import { catchError, map, Observable, of } from "rxjs";
import { MatDialogRef } from "@angular/material/dialog";

@Component({
  selector: "app-filter-dialog",
  templateUrl: "filter-dialog.component.html",
  styleUrls: ["filter-dialog.component.scss"],
  // changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FilterDialogComponent implements OnInit {
  public filterForm: FormGroup = new FormGroup({
    smarts: new FormControl("", {
      validators: [],
      asyncValidators: [(control) => this.validateSubstructure(control)],
      updateOn: "blur",
    }),
    nHeavyMin: new FormControl("", {
      validators: [Validators.pattern(/\d+/)],
      updateOn: "blur",
    }),
    nHeavyMax: new FormControl("", {
      validators: [Validators.pattern(/\d+/)],
      updateOn: "blur",
    }),
  });

  constructor(
    private apiService: ApiService,
    private dialogRef: MatDialogRef<FilterDialogComponent>
  ) {}

  ngOnInit(): void {}

  validateSubstructure(
    control: AbstractControl
  ): Observable<ValidationErrors | null> {
    return this.apiService.isSubstructureValid(control.value).pipe(
      map((isValid) => {
        return isValid ? null : { invalid: true };
      }),
      catchError((err) => {
        return of({ internal: true });
      })
    );
  }

  getSubstructureErrorMessage() {
    if (this.filterForm.get("smarts")?.hasError("internal"))
      return "internal error";

    return this.filterForm.get("smarts")?.hasError("invalid")
      ? "invalid SMARTS"
      : "internal error";
  }

  getIntegerErrorMessage(control: AbstractControl | null) {
    return control?.hasError("pattern") ? "must be an integer" : "";
  }

  onSubmit() {
    if (this.filterForm.invalid) return;
    this.dialogRef.close(this.filterForm.value);
  }
}
