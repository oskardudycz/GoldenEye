using System.Data.Entity;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Context;
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

        public IDbSet<TaskEntity> Tasks { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<TaskEntity>()
                .ToTable("Tasks")
                .Ignore(s => s.Progress)
                .HasKey(o => o.Id);

        }
    }
}