using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;

namespace Backend.Business.Context
{
    public class THBContext: DataContext<THBContext>, ITHBContext
    {
        public IDbSet<Task> Tasks { get; set; }
        public IDbSet<ClientEntity> Clients { get; set; }
        public IDbSet<TaskTypeEntity> TaskTypes { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {

            modelBuilder.Entity<ClientEntity>()
                        .HasMany(c => c.TaskTypes)
                        .WithMany(t => t.Clients)
                        .Map(ct =>
                        {
                            ct.MapLeftKey("ClientId");
                            ct.MapRightKey("TaskTypeId");
                            ct.ToTable("ClientTaskType");
                        });
            modelBuilder.Entity<ClientEntity>()
                    .HasMany(c => c.Users)
                    .WithRequired(u => u.Client)
                    .HasForeignKey(u => u.ClientRefId);
        }
    }
}