using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Data.Entity.Infrastructure;
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
            Database.SetInitializer<ModelerContext>(null);
        }

        public virtual DbSet<ClientEntity> ClientEntities { get; set; }
        public virtual DbSet<TaskEntity> TaskEntities { get; set; }
        public virtual DbSet<TaskTypeEntity> TaskTypeEntities { get; set; }
        public virtual DbSet<UserEntity> UserEntities { get; set; }
        public virtual DbSet<Task> Tasks { get; set; }

        public DbQuery<Customer> Customers
        {
            get
            {
                return Set<Customer>().AsNoTracking();
            }
        }
        public DbQuery<TaskType> TaskTypes
        {
            get
            {
                return Set<TaskType>().AsNoTracking();
            }
        }

        public int AdOrUpdateTask(Task task)
        {
            if(!task.ModificationDate.HasValue)
                task.ModificationDate = DateTime.Now;
            
            var request = new TaskSaveRequest(1, task);

            var serializer = new TaskXmlSerializer();

            var id = new SqlParameter("Id", SqlDbType.Int) { Value = task.Id };
            var xmlDataIn = new SqlParameter("XMLDataIn", SqlDbType.NVarChar, -1) { Value = serializer.Serialize(request) };
            var xmlDataOut = new SqlParameter("XMLDataOut", SqlDbType.NVarChar, -1) { Direction = ParameterDirection.Output };

            Database.ExecuteSqlCommand("[Portal].[AddOrUpdateTask] @Id, @XMLDataIn, @XMLDataOut OUT", id, xmlDataIn, xmlDataOut);
            
            var response = serializer.Deserialize((string)xmlDataOut.Value);
 
            if(response.Result.Error != null)
                throw new DataException(response.Result.Error.ErrorMessage);

            return response.Result.Value.Ref.Id;
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Customer>()
                .ToTable("Portal.Customers");

            modelBuilder.Entity<TaskType>()
                .ToTable("Portal.TaskTypes");

            modelBuilder.Entity<Task>()
                .ToTable("Portal.Tasks")
                .HasKey(o => o.Id)
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

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
