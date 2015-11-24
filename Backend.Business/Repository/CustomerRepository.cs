using System.Data.Entity;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class CustomerRepository : ReadonlyRepositoryBase<Customer>, ICustomerRepository
    {
        public CustomerRepository(ITHBContext context)
            : base(context, context.Customers)
        {
        }
    }
}