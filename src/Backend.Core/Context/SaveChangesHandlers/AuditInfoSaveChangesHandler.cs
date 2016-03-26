using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.IOC;
using GoldenEye.Shared.Core.Security;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;

namespace GoldenEye.Backend.Core.Context.SaveChangesHandlers
{
    public class AuditInfoSaveChangesHandler : ISaveChangesHandler
    {
        public void Handle(DbContext context)
        {
            var addedEntities = context.ChangeTracker.Entries()
                            .Where(e => e.State == EntityState.Added)
                            .Select(e => e.Entity)
                            .OfType<AuditableEntity>();
            var updatedEntities = context.ChangeTracker.Entries()
                            .Where(e => e.State == EntityState.Modified)
                            .Select(e => e.Entity)
                            .OfType<AuditableEntity>();

            Handle(addedEntities, updatedEntities, IOCContainer.Get<IUserInfoProvider>());
        }

        public void Handle(IEnumerable<AuditableEntity> addedEntities,
            IEnumerable<AuditableEntity> modifiedEntities, IUserInfoProvider userInfoProvider)
        {
            foreach (var entity in addedEntities)
            {
                entity.Created = DateTime.Now;
                entity.CreatedBy = userInfoProvider.GetCurrentUserId<int>();
                entity.LastModified = entity.Created;
                entity.LastModifiedBy = userInfoProvider.GetCurrentUserId<int>();
            }

            foreach (var entity in modifiedEntities)
            {
                entity.LastModified = DateTime.Now;
                entity.LastModifiedBy = userInfoProvider.GetCurrentUserId<int>();
            }
        }
    }
}
