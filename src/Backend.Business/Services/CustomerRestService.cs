using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Repository;
using GoldenEye.Backend.Core.Service;
using GoldenEye.Shared.Business.DTOs;

namespace GoldenEye.Backend.Business.Services
{
    public class CustomerRestService : ReadonlyRestServiceBase<CustomerDTO, Customer>, ICustomerRestService
    {
        public CustomerRestService(ICustomerRepository repository)
            : base(repository)
        {
        }
    }
}