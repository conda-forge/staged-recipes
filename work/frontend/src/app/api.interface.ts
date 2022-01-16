export interface RangeFilter {
  type: string;

  column: string;

  lt?: number;
  le?: number;

  gt?: number;
  ge?: number;
}

export interface SMARTSFilter {
  type: string;

  smarts: string;
}

export interface GETMoleculeResponseLinks {
  img: string;
}

export interface GETMoleculeResponse {
  self: string;
  id: number;

  smiles: string;

  _links: GETMoleculeResponseLinks;
}

export interface GETMoleculesResponseMetadata {
  cursor?: string;
  move_to: string;

  per_page: number;

  sort_by?: [string, string];
  filters: (SMARTSFilter | RangeFilter)[];
}

export interface GETMoleculesResponseLinks {
  self: string;

  first: string;
  prev: string;
  next: string;
  last: string;
}

export interface GETMoleculesResponse {
  _metadata: GETMoleculesResponseMetadata;
  _links: GETMoleculesResponseLinks;

  contents: GETMoleculeResponse[];
}
