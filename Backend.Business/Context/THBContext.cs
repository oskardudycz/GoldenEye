using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Linq;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using Backend.Business.Utils.Serialization;

namespace Backend.Business.Context
{
    public class THBContext: DataContext<THBContext>, ITHBContext
    {
        public THBContext()
            : base("name=THB-B2B")
        {
            Database.SetInitializer<THBContext>(null);
        }

        public IDbSet<Task> Tasks { get; set; }
        public IDbSet<ClientEntity> Clients { get; set; }

        public DbQuery<Customer> Customers
        {
            get
            {
                return Set<Customer>().AsNoTracking();
            }
        }
        public IQueryable<TaskType> TaskTypes
        {
            get
            {
                return Set<TaskType>().AsNoTracking();
            }
        }

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


            modelBuilder.Entity<Customer>()
                .ToTable("Portal.Customers")
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

            modelBuilder.Entity<TaskType>()
                .ToTable("Portal.TaskTypes")
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

            modelBuilder.Entity<Task>()
                .ToTable("Portal.Tasks")
                .Ignore(s => s.Progress)
                .HasKey(o => o.Id)
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);
        }
        
        public int AddOrUpdateTask(Task task)
        {
            if (!task.ModificationDate.HasValue)
                task.ModificationDate = DateTime.Now;

            var request = new TaskSaveRequest(1, task);

            var serializer = new TaskXmlSerializer();

            var id = new SqlParameter("Id", SqlDbType.Int) { Value = task.Id };
            var xmlDataIn = new SqlParameter("XMLDataIn", SqlDbType.NVarChar, -1) { Value = serializer.Serialize(request) };
            var xmlDataOut = new SqlParameter("XMLDataOut", SqlDbType.NVarChar, -1) { Direction = ParameterDirection.Output };

            Database.ExecuteSqlCommand("[Portal].[AddOrUpdateTask] @Id, @XMLDataIn, @XMLDataOut OUT", id, xmlDataIn, xmlDataOut);

            var response = serializer.Deserialize((string)xmlDataOut.Value);

            if (response.Result.Error != null)
                throw new DataException(response.Result.Error.ErrorMessage);

            return response.Result.Value.Ref.Id;
        }
    }
}