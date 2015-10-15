using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

namespace Backend.Core.Context
{
    public interface IDataContext
    {
        DbEntityEntry<T> Entry<T>(T entity) where T : class;
        int SaveChanges();
        DbContextTransaction BeginTransaction();
        void Dispose();
    }
}
