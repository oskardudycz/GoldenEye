using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public class CustomerRepository : ReadonlyRepositoryBase<Customer>, ICustomerRepository
    {
        public CustomerRepository(ISampleContext context)
            : base(context, context.Customers)
        {
        }
    }
}