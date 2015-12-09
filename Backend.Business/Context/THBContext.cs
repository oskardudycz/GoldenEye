using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Linq;
using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using Backend.Business.Repository;
using Backend.Business.Utils.Serialization;

namespace Backend.Business.Context
{
    public class THBContext: DataContext<THBContext>, ITHBContext
    {
        public THBContext()
            : base("name=DBConnectionString")
        {
            Database.SetInitializer<THBContext>(null);
        }

        public THBContext(IConnectionProvider connectionProvider)
            : base(connectionProvider)
        {
            Database.SetInitializer<THBContext>(null);
        }

        public IDbSet<TaskEntity> Tasks { get; set; }
        public IDbSet<ClientEntity> Clients { get; set; }

        public DbQuery<Customer> Customers
        {
            get
            {
                return Set<Customer>().AsNoTracking();
            }
        }
        public DbQuery<TaskTypeEntity> TaskTypes
        {
            get
            {
                return Set<TaskTypeEntity>().AsNoTracking();
            }
        }
        public IQueryable<ModelerUserEntity> ModelerUsers
        {
            get
            {
                return Set<ModelerUserEntity>().AsNoTracking();
            }
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ClientEntity>()
                    .HasMany(c => c.Users)
                    .WithRequired(u => u.Client)
                    .HasForeignKey(u => u.ClientRefId);


            modelBuilder.Entity<Customer>()
                .ToTable("Portal.Customers")
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

            modelBuilder.Entity<TaskTypeEntity>()
                .ToTable("Portal.TaskTypes")
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

            modelBuilder.Entity<TaskEntity>()
                .ToTable("Portal.Tasks")
                .Ignore(s => s.Progress)
                .HasKey(o => o.Id)
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);

            modelBuilder.Entity<ModelerUserEntity>()
                .ToTable("Portal.ModelerUsers")
                .Ignore(s => s.CanLogin)
                .HasKey(o => o.Id)
                .Property(s => s.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);
        }
        
        public int AddOrUpdateTask(TaskEntity task)
        {
            if (!task.ModificationDate.HasValue)
                task.ModificationDate = DateTime.Now;

            var repository = new ModelerUserRepository(this);

            var userId = repository.FindId(task.ModificationBy);

            var request = new TaskSaveRequest(userId, task);

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