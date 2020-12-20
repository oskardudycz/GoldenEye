using System;
using GoldenEye.Events;
using Newtonsoft.Json;

namespace Tickets.Reservations.Events
{
    public class ReservationConfirmed : IEvent
    {
        public Guid ReservationId { get; }
        
        public Guid StreamId => ReservationId;

        [JsonConstructor]
        private ReservationConfirmed(Guid reservationId)
        {
            ReservationId = reservationId;
        }

        public static ReservationConfirmed Create(Guid reservationId)
        {
            return new ReservationConfirmed(reservationId);
        }
    }
}
