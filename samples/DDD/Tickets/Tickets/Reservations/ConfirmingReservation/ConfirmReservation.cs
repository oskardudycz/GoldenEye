using System;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Commands;
using GoldenEye.Exceptions;
using GoldenEye.Repositories;
using MediatR;

namespace Tickets.Reservations.ConfirmingReservation;

public class ConfirmReservation : ICommand
{
    public Guid ReservationId { get; }

    private ConfirmReservation(Guid reservationId)
    {
        ReservationId = reservationId;
    }

    public static ConfirmReservation Create(Guid? reservationId)
    {
        if (!reservationId.HasValue)
            throw new ArgumentNullException(nameof(reservationId));

        return new ConfirmReservation(reservationId.Value);
    }
}

internal class HandleConfirmReservation:
    ICommandHandler<ConfirmReservation>
{
    private readonly IRepository<Reservation> repository;

    public HandleConfirmReservation(
        IRepository<Reservation> repository
    )
    {
        this.repository = repository;
    }

    public async Task<Unit> Handle(ConfirmReservation command, CancellationToken cancellationToken)
    {
        var reservation = await repository.FindById(command.ReservationId, cancellationToken)
                          ?? throw NotFoundException.For<Reservation>(command.ReservationId);

        reservation.Confirm();

        await repository.Update(reservation, cancellationToken);

        return Unit.Value;
    }
}