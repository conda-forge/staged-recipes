import {
  ChangeDetectionStrategy,
  Component,
  EventEmitter,
  Input,
  OnInit,
  Output,
} from "@angular/core";

@Component({
  selector: "app-paginator",
  templateUrl: "paginator.component.html",
  styleUrls: ["paginator.component.scss"],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PaginatorComponent implements OnInit {
  @Input()
  public enableFirst: boolean = false;
  @Input()
  public enablePrev: boolean = false;
  @Input()
  public enableNext: boolean = false;
  @Input()
  public enableLast: boolean = false;

  @Output()
  first: EventEmitter<MouseEvent> = new EventEmitter<MouseEvent>();
  @Output()
  prev: EventEmitter<MouseEvent> = new EventEmitter<MouseEvent>();
  @Output()
  next: EventEmitter<MouseEvent> = new EventEmitter<MouseEvent>();
  @Output()
  last: EventEmitter<MouseEvent> = new EventEmitter<MouseEvent>();

  constructor() {}

  ngOnInit(): void {}
}
