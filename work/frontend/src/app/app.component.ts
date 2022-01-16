import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  OnDestroy,
  OnInit,
} from "@angular/core";
import {
  GETMoleculesResponse,
  RangeFilter,
  SMARTSFilter,
} from "./api.interface";
import { BehaviorSubject, mergeMap, Subject, takeUntil } from "rxjs";
import { ApiService } from "./api.service";
import { ActivatedRoute, Router } from "@angular/router";
import { MatDialog } from "@angular/material/dialog";
import { FilterDialogComponent } from "./filter-dialog.component";
import { BASE_API_URL } from "./app.module";
import { MatSnackBar } from "@angular/material/snack-bar";

@Component({
  selector: "app-root",
  templateUrl: "app.component.html",
  styleUrls: ["app.component.scss"],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AppComponent implements OnInit, OnDestroy {
  public readonly BASE_API_URL: string = BASE_API_URL;
  response: GETMoleculesResponse | undefined;

  destroy$: Subject<boolean> = new Subject<boolean>();
  isLoading$: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(true);

  public constructor(
    private apiService: ApiService,
    private changeRef: ChangeDetectorRef,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MatDialog,
    private errorBar: MatSnackBar
  ) {}

  public ngOnInit() {
    this.route.queryParamMap
      .pipe(
        mergeMap((params) => {
          this.isLoading$.next(true);

          let filters: (SMARTSFilter | RangeFilter | string)[] = params.has(
            "substr"
          )
            ? [
                {
                  type: "smarts",
                  smarts: atob(params.get("substr") as string),
                },
              ]
            : [];

          if (params.has("n_heavy"))
            filters.push(
              ...params.getAll("n_heavy").map((value) => {
                return value;
              })
            );

          return this.apiService.getMolecules(
            params.get("page") || undefined,
            params.get("per_page") || undefined,
            params.get("sort_by") || undefined,
            filters
          );
        })
      )
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (response) => {
          this.isLoading$.next(false);

          this.response = response;
          this.changeRef.detectChanges();
        },
        error: (err) => {
          this.isLoading$.next(false);
          this.response = undefined;

          console.log(err);
          this.errorBar.open("An internal error occurred", "Dismiss");

          this.changeRef.detectChanges();
        },
      });
  }

  public ngOnDestroy() {
    this.destroy$.next(true);
    this.destroy$.unsubscribe();
  }

  public onPageChanged(endpoint: string | undefined) {
    if (!endpoint) return;

    this.router
      .navigateByUrl(endpoint.replace("/api/molecules", "/"))
      .catch(console.error);
  }

  public onSort(column: string | undefined, order_by: string | undefined) {
    const httpQueryParams = this.apiService.getMoleculesParams(
      undefined,
      this.response?._metadata.per_page,
      column && order_by ? [column, order_by] : undefined,
      this.response?._metadata.filters
    );

    const queryParams: { [key: string]: string[] } = {};
    httpQueryParams.keys().forEach((key) => {
      queryParams[key] = httpQueryParams.getAll(key) as string[];
    });

    this.router.navigate(["/"], { queryParams }).catch(console.error);
  }

  public onFilterClicked() {
    const dialogRef = this.dialog.open(FilterDialogComponent, {
      restoreFocus: false,
      height: "260px",
    });
    dialogRef.afterClosed().subscribe((result) => this.onFilter(result));
  }

  public onFilter(result?: {
    smarts: string;
    nHeavyMin: string;
    nHeavyMax: string;
  }) {
    if (!result) return;

    const filters: (SMARTSFilter | RangeFilter)[] = [];

    if (result.smarts) filters.push({ type: "smarts", smarts: result.smarts });
    if (result.nHeavyMin.length > 0 || result.nHeavyMax.length > 0)
      filters.push({
        type: "range",
        column: "n_heavy",
        le:
          result.nHeavyMax.length > 0 ? parseInt(result.nHeavyMax) : undefined,
        ge:
          result.nHeavyMin.length > 0 ? parseInt(result.nHeavyMin) : undefined,
      });

    const httpQueryParams = this.apiService.getMoleculesParams(
      undefined,
      this.response?._metadata.per_page,
      this.response?._metadata.sort_by,
      filters
    );

    const queryParams: { [key: string]: string[] } = {};
    httpQueryParams.keys().forEach((key) => {
      queryParams[key] = httpQueryParams.getAll(key) as string[];
    });

    this.router.navigate(["/"], { queryParams }).catch(console.error);
  }
}
