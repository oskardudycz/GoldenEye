using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using Backend.Core.Service;
using Shared.Core.DTOs;

namespace Frontend.Web.Core.Controllers
{
    public abstract class ReadonlyRestControllerBase<TService, TDto> : ApiController where TService : IReadonlyRestService<TDto> where TDto : IDTO
    {
        protected TService Service;

        protected ReadonlyRestControllerBase(TService service)
        {
            Service = service;
        }

        protected ReadonlyRestControllerBase()
        {
        }

        public IQueryable<TDto> Get()
        {
            return Service.Get();
        }

        public async Task<IHttpActionResult> Get(int id)
        {
            var dto = await Service.Get(id);
            if (dto == null)
            {
                return NotFound();
            }

            return Ok(dto);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                Service.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}