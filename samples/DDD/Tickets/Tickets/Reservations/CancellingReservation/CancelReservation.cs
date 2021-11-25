using System;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Commands;
using GoldenEye.Exceptions;
using GoldenEye.Repositories;
using MediatR;

namespace Tickets.Reservations.CancellingReservation;

public class CancelReservation : ICommand
{
    public Guid ReservationId { get; }

    private CancelReservation(Guid reservationId)
    {
        ReservationId = reservationId;
    }

    public static CancelReservation Create(Guid? reservationId)
    {
        if (!reservationId.HasValue)
            throw new ArgumentNullException(nameof(reservationId));

        return new CancelReservation(reservationId.Value);
    }
}

internal class HandleCancelReservation:
    ICommandHandler<CancelReservation>
{
    private readonly IRepository<Reservation> repository;

    public HandleCancelReservation(
        IRepository<Reservation> repository
    )
    {
        this.repository = repository;
    }

    public async Task<Unit> Handle(CancelReservation command, CancellationToken cancellationToken)
    {
        var reservation = await repository.FindById(command.ReservationId, cancellationToken)
                          ?? throw NotFoundException.For<Reservation>(command.ReservationId);

        reservation.Cancel();

        await repository.Update(reservation, cancellationToken);

        return Unit.Value;
    }
}