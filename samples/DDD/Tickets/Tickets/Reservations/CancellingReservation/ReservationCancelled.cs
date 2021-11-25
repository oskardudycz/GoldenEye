using System;
using GoldenEye.Events;
using Newtonsoft.Json;

namespace Tickets.Reservations.CancellingReservation;

public class ReservationCancelled : IEvent
{
    public Guid StreamId => ReservationId;
    public Guid ReservationId { get; }

    [JsonConstructor]
    private ReservationCancelled(Guid reservationId)
    {
        ReservationId = reservationId;
    }

    public static ReservationCancelled Create(Guid reservationId)
    {
        return new ReservationCancelled(reservationId);
    }
}