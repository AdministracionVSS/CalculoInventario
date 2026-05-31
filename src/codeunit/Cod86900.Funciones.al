codeunit 86900 "Funciones"
{   

    procedure CreaMovReserva(OldTrackingSpecification: Record "Tracking Specification" temporary)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        CurrentEntryStatus: Enum "Reservation Status";
        ReservEntry1: Record "Reservation Entry";

    begin
        CurrentEntryStatus := CurrentEntryStatus::Prospect;
        CreateReservEntry.SetDates(0D, OldTrackingSpecification."Expiration Date");

        ReservEntry1."Lot No." := OldTrackingSpecification."Lot No.";
        ReservEntry1."Expiration Date" := OldTrackingSpecification."Expiration Date";

        CreateReservEntry.CreateReservEntryFor(
                              OldTrackingSpecification."Source Type",
                              OldTrackingSpecification."Source Subtype",
                              OldTrackingSpecification."Source ID",
                              OldTrackingSpecification."Source Batch Name",
                              OldTrackingSpecification."Source Prod. Order Line",
                              OldTrackingSpecification."Source Ref. No.",
                              OldTrackingSpecification."Qty. per Unit of Measure",
                              0,
                              OldTrackingSpecification."Quantity (Base)", ReservEntry1);


        CreateReservEntry.CreateEntry(
        OldTrackingSpecification."Item No.",
          OldTrackingSpecification."Variant Code",
          OldTrackingSpecification."Location Code",
          OldTrackingSpecification.Description,
          WORKDATE,
          WORKDATE, 0, CurrentEntryStatus);

    end;
}