using System.Data.Entity;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using System.Collections.Generic;

namespace GoldenEye.Backend.Business.Context
{
    public class SampleContext: DataContext<SampleContext>, ISampleContext
    {
        public SampleContext()
            : base("name=DBConnectionString")
        {
        }

        public SampleContext(IConnectionProvider connectionProvider)
            : base(connectionProvider)
        {
        }

        public SampleContext(IConnectionProvider connectionProvider, IEnumerable<ISaveChangesHandler> saveHandlers)
            : base(connectionProvider, saveHandlers)
        {
        }

        public IDbSet<TaskEntity> Tasks { get; set; }

        public IDbSet<Customer> Customers { get; set; }
        public IDbSet<TaskTypeEntity> TaskTypes { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Customer>()
                .HasKey(o => o.Id)
                .ToTable("Customers");

            modelBuilder.Entity<TaskTypeEntity>()
                .HasKey(o => o.Id)
                .ToTable("TaskTypes");

            modelBuilder.Entity<TaskEntity>()
                .ToTable("Tasks")
                .Ignore(s => s.Progress)
                .HasKey(o => o.Id);

        }
    }
}