using System;
using System.Linq;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Core.Repositories.SaveChangesHandlers.Base;
using GoldenEye.Core.Security;

namespace GoldenEye.Backend.Core.Repositories.SaveChangesHandlers
{
    public class AuditInfoSaveChangesHandler: ISaveChangesHandler
    {
        public void Handle(IProvidesAuditInfo context)
        {
            var addedEntities = context.Changes
                .Where(ch => ch.State == EntityEntryState.Added)
                .Select(ch => ch.Entity)
                .OfType<IAuditableEntity>();
            var updatedEntities = context.Changes
                .Where(ch => ch.State == EntityEntryState.Modified)
                .Select(ch => ch.Entity)
                .OfType<IAuditableEntity>();

            var currentUserId = UserInfoProvider.Instance.GetCurrenUserId();

            var currentDate = DateTime.Now;

            foreach (var entity in addedEntities)
            {
                entity.Created = currentDate;
                entity.CreatedBy = currentUserId;
            }

            foreach (var entity in updatedEntities)
            {
                entity.LastModified = currentDate;
                entity.LastModifiedBy = currentUserId;
            }
        }
    }
}
