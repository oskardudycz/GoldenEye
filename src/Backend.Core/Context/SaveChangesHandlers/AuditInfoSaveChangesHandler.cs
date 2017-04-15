using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Security;
using System;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers.Base;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public class AuditInfoSaveChangesHandler : ISaveChangesHandler
    {
        public void Handle(IDataContext dataContext)
        {
            if (dataContext as IProvidesAuditInfo == null)
                return;

            var context = (IProvidesAuditInfo)dataContext;

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
