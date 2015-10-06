using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Backend.Core.Service
{
    public abstract class ServiceBase: IService
    {
        private bool _disposed;

        public void Dispose()
        {
            Dispose(true);

            // Use SupressFinalize in case a subclass 
            // of this type implements a finalizer.
            GC.SuppressFinalize(this);
        }
        private void Dispose(bool disposing)
        {
            if (_disposed) return;

            if (disposing)
            {
                // Clear all property values that maybe have been set
                // when the class was instantiated
                OnDispose();
            }

            // Indicate that the instance has been disposed.
            _disposed = true;
        }

        protected abstract void OnDispose();
    }
}