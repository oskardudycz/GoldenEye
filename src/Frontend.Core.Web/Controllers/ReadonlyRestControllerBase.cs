using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.OData;
using GoldenEye.Shared.Core.Objects.DTO;
using GoldenEye.Shared.Core.Services;

namespace GoldenEye.Frontend.Core.Web.Controllers
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
        [EnableQuery]
        public virtual IQueryable<TDto> Get()
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