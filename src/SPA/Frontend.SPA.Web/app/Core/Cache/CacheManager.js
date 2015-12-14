function CacheManager() {
    var self = this;

    self.Get = function (key) {
        var itemJSON = localStorage.getItem(key);

        if (!itemJSON || itemJSON === "undefined")
            return undefined;

        return JSON.parse(itemJSON);
    }

    self.Set = function (key, obj) {
        localStorage.setItem(key, JSON.stringify(obj));
    }

    self.Clear = function (key) {
        localStorage.removeItem(key);
    }

    self.ClearAll = function (key) {
        localStorage.clear();
    }

    self.Exists = function(key) {
        return localStorage.getItem(key) == undefined;
    }
}

var cache = new CacheManager();