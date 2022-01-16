import { Injectable } from "@angular/core";
import {
  HttpClient,
  HttpErrorResponse,
  HttpParams,
} from "@angular/common/http";
import { catchError, Observable, of, throwError } from "rxjs";
import {
  GETMoleculesResponse,
  RangeFilter,
  SMARTSFilter,
} from "./api.interface";
import { BASE_API_URL } from "./app.module";

@Injectable({
  providedIn: "root",
})
export class ApiService {
  constructor(private httpClient: HttpClient) {}

  private static handleError(response: HttpErrorResponse) {
    let errorMessage: string;

    if (response.error instanceof ErrorEvent)
      errorMessage = `Error: ${response.error.message}`;
    else
      errorMessage = `Error Code: ${response.status}\nMessage: ${response.message}`;

    return throwError(() => new Error(errorMessage));
  }

  public getEndpoint<Type>(
    endpoint: string,
    params?: HttpParams
  ): Observable<Type> {
    const options = !params ? {} : { params };

    return this.httpClient
      .get<Type>(`${BASE_API_URL}${endpoint}`, options)
      .pipe(catchError(ApiService.handleError));
  }

  public getMoleculesParams(
    page?: [string, string] | string,
    per_page?: number | string,
    sort_by?: [string, string] | string,
    filters?: (SMARTSFilter | RangeFilter | string)[]
  ): HttpParams {
    let params = new HttpParams();

    filters = filters ? filters : [];

    if (per_page) params = params.set("per_page", per_page);

    if (page)
      params = params.set(
        "page",
        typeof page === "string" ? page : `${page[1]}(${page[0]})`
      );
    if (sort_by)
      params = params.set(
        "sort_by",
        typeof sort_by === "string" ? sort_by : `${sort_by[1]}(${sort_by[0]})`
      );

    filters.map((columnFilter) => {
      if (typeof columnFilter === "string") {
        params = params.append("n_heavy", columnFilter);
        return;
      }

      columnFilter = columnFilter as RangeFilter | SMARTSFilter;

      switch (columnFilter.type.toLowerCase()) {
        case "range":
          columnFilter = columnFilter as RangeFilter;

          if (columnFilter.le)
            params = params.append("n_heavy", `le(${columnFilter.le})`);
          if (columnFilter.lt)
            params = params.append("n_heavy", `lt(${columnFilter.lt})`);
          if (columnFilter.gt)
            params = params.append("n_heavy", `gt(${columnFilter.gt})`);
          if (columnFilter.ge)
            params = params.append("n_heavy", `ge(${columnFilter.ge})`);

          break;
        case "smarts":
          columnFilter = columnFilter as SMARTSFilter;
          params = params.set(
            "substr",
            btoa(columnFilter.smarts).replace(/=+$/, "")
          );

          break;
      }
    });

    return params;
  }

  public getMolecules(
    page?: [string, string] | string,
    per_page?: number | string,
    sort_by?: [string, string] | string,
    filters?: (SMARTSFilter | RangeFilter | string)[]
  ): Observable<GETMoleculesResponse> {
    const params = this.getMoleculesParams(page, per_page, sort_by, filters);
    return this.getEndpoint("/molecules", params);
  }

  public isSubstructureValid(value?: string): Observable<boolean> {
    if (value === undefined || value.length == 0) return of(true);

    value = btoa(value).replace(/=+$/, "");

    return this.httpClient
      .get<boolean>(`${BASE_API_URL}/validation/substr/${value}`)
      .pipe(catchError(ApiService.handleError));
  }
}
