using Backend.Business.Entities;
using Backend.Core.Context;

namespace Backend.Business.Context
{
    using System.Data.Entity;

    public class ModelerContext : DataContext<ModelerContext>
    {
        public virtual DbSet<C_Zlecenie__nietabelaryczne> C_Zlecenie__nietabelaryczne { get; set; }
        public virtual DbSet<C_Zlecenie__nietabelaryczne_Cechy_Hist> C_Zlecenie__nietabelaryczne_Cechy_Hist { get; set; }
        public virtual DbSet<Cechy> Cechies { get; set; }
        public virtual DbSet<ClientEntity> ClientEntities { get; set; }
        public virtual DbSet<TaskEntity> TaskEntities { get; set; }
        public virtual DbSet<TaskTypeEntity> TaskTypeEntities { get; set; }
        public virtual DbSet<UserEntity> UserEntities { get; set; }
        public virtual DbSet<Task> Tasks { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<C_Zlecenie__nietabelaryczne>()
                .HasMany(e => e.C_Zlecenie__nietabelaryczne1)
                .WithOptional(e => e.C_Zlecenie__nietabelaryczne2)
                .HasForeignKey(e => e.IdArch);

            modelBuilder.Entity<C_Zlecenie__nietabelaryczne>()
                .HasMany(e => e.C_Zlecenie__nietabelaryczne11)
                .WithOptional(e => e.C_Zlecenie__nietabelaryczne3)
                .HasForeignKey(e => e.IdArchLink);

            modelBuilder.Entity<C_Zlecenie__nietabelaryczne_Cechy_Hist>()
                .Property(e => e.ValDecimal)
                .HasPrecision(12, 5);

            modelBuilder.Entity<Cechy>()
                .Property(e => e.Format)
                .IsUnicode(false);

            modelBuilder.Entity<Cechy>()
                .Property(e => e.StatusA)
                .IsUnicode(false);

            modelBuilder.Entity<Cechy>()
                .Property(e => e.StatusB)
                .IsUnicode(false);

            modelBuilder.Entity<Cechy>()
                .Property(e => e.StatusC)
                .IsUnicode(false);

            modelBuilder.Entity<Cechy>()
                .Property(e => e.Widocznosc)
                .IsUnicode(false);

            //modelBuilder.Entity<ClientEntity>()
            //    .HasMany(e => e.UserEntities)
            //    .WithRequired(e => e.ClientEntity)
            //    .HasForeignKey(e => e.ClientRefId);

            //modelBuilder.Entity<ClientEntity>()
            //    .HasMany(e => e.TaskTypeEntities)
            //    .WithMany(e => e.ClientEntities)
            //    .Map(m => m.ToTable("ClientTaskType").MapLeftKey("ClientId").MapRightKey("TaskTypeId"));

            modelBuilder.Entity<Task>()
                .Property(e => e.TaskName)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Customer)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.CustomerColor)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Date)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Type)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.IsInternal)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Amount)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.PlannedTime)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.PlannedStartDate)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.PlannedEndDate)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Color)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.PlanningDate)
                .IsUnicode(false);

            modelBuilder.Entity<Task>()
                .Property(e => e.Description)
                .IsUnicode(false);
        }
    }
}
