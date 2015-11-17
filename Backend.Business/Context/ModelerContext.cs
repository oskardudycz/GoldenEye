using System.Data;
using System.Data.SqlClient;
using Backend.Business.Entities;
using Backend.Business.Utils.Serialization;
using Backend.Core.Context;

namespace Backend.Business.Context
{
    using System.Data.Entity;

    public class ModelerContext : DataContext<ModelerContext>
    {
        public ModelerContext()
            : base("name=THB-B2B")
        {

        }

        public virtual DbSet<ClientEntity> ClientEntities { get; set; }
        public virtual DbSet<TaskEntity> TaskEntities { get; set; }
        public virtual DbSet<TaskTypeEntity> TaskTypeEntities { get; set; }
        public virtual DbSet<UserEntity> UserEntities { get; set; }
        public virtual DbSet<Task> Tasks { get; set; }
        public virtual DbSet<Customer> Customers { get; set; }
        public virtual DbSet<TaskType> TaskTypes { get; set; }

        public bool SaveTask(Task task)
        {
            var xmlDataIn = new SqlParameter("XMLDataIn", SqlDbType.NVarChar, -1) { Value = new TaskXmlSerializer().Serialize(new TaskSaveRequest(1, task)) };
            var xmlDataOut = new SqlParameter("XMLDataOut", SqlDbType.NVarChar, -1) { Direction = ParameterDirection.Output };

            var result = Database.ExecuteSqlCommand("THB.Units_Save @XMLDataIn, @XMLDataOut OUT", xmlDataIn, xmlDataOut);

            return result == 1;
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            //modelBuilder.Entity<ClientEntity>()
            //    .HasMany(e => e.UserEntities)
            //    .WithRequired(e => e.ClientEntity)
            //    .HasForeignKey(e => e.ClientRefId);

            //modelBuilder.Entity<ClientEntity>()
            //    .HasMany(e => e.TaskTypeEntities)
            //    .WithMany(e => e.ClientEntities)
            //    .Map(m => m.ToTable("ClientTaskType").MapLeftKey("ClientId").MapRightKey("TaskTypeId"));

        }
    }
}
