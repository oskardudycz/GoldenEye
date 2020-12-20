using System;
using GoldenEye.Events;
using Newtonsoft.Json;

namespace Tickets.Reservations.Events
{
    public class ReservationCancelled : IEvent
    {
        public Guid ReservationId { get; }

        public Guid StreamId => ReservationId;

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
}
