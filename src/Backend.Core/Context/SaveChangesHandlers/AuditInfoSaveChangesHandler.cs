using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Security;
using System;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers.Base;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public class AuditInfoSaveChangesHandler : ISaveChangesHandler
    {
        public void Handle(IDataContext context)
        {
            var addedEntities = context.GetAddedEntities()
                            .OfType<AuditableEntity>();
            var updatedEntities = context.GetAddedEntities()
                            .OfType<AuditableEntity>();

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
