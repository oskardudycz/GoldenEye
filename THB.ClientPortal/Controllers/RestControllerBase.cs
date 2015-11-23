using System.Linq;
using System.Net;
using System.Web.Http;
using System.Threading.Tasks;
using Backend.Core.Service;
using Shared.Core.DTOs;

namespace Frontend.Web.Controllers
{
    public abstract class RestControllerBase<TService, TDto> : ApiController
        where TDto : IDTO
        where TService : IRestService<TDto>
    {
        protected TService Service;

        protected RestControllerBase(TService service)
        {
            Service = service;
        }

        protected RestControllerBase()
        {
        }

        // GET: api/{controller}
        public IQueryable<TDto> Get()
        {
            return Service.Get();
        }

        // GET: api/{controller}/5
        //[ResponseType(typeof(TDTO))]
        public async Task<IHttpActionResult> Get(int id)
        {
            var dto = await Service.Get(id);
            if (dto == null)
            {
                return NotFound();
            }

            return Ok(dto);
        }

        // PUT: api/{controller}/5
        //[ResponseType(typeof(void))]
        public virtual async Task<IHttpActionResult> Put(TDto dto)
        {

            if (!ModelState.IsValid)// || id != dto.Id)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.Put(dto);

            return Ok(result);
        }

        // POST: api/{controller}
        //[ResponseType(typeof(TDTO))]
        public virtual async Task<IHttpActionResult> Post(TDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await Service.Post(dto);

            return Ok(result);
        }

        // DELETE: api/{controller}/5
        //[ResponseType(typeof(TDTO))]
        public async Task<IHttpActionResult> Delete(int id)
        {
            var wasDeleted = await Service.Delete(id);
            if (!wasDeleted)
            {
                return NotFound();
            }

            return StatusCode(HttpStatusCode.NoContent);
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
