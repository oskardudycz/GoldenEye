function CacheManager() {
    var self = this;

    self.Get = function (key) {
        return localStorage.getItem(key);
    }

    self.Set = function (key, obj) {
        localStorage.setItem(key, obj);
    }

    self.Clear = function (key) {
        localStorage.removeItem(key);
    }

    self.Exists = function(key) {
        return localStorage.getItem(key) == undefined;
    }
}

var cache = new CacheManager();