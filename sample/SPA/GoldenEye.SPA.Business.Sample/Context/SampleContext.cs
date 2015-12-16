using System.Data.Entity;
using GoldenEye.Backend.Core.Context;
using GoldenEye.SPA.Business.Sample.Entities;

namespace GoldenEye.SPA.Business.Sample.Context
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
                .HasKey(o => o.Id);

        }
    }
}