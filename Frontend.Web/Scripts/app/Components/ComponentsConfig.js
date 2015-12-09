function ComponentsConfig() {
    this.init = function () {

        ko.components.register("LoginTopMenu", {
            template: { fromUrl: "Login/LoginTopMenuView.html" },
            viewModel: { fromUrl: "Login/LoginViewModel.js" }
        });
    }
}

var componentsConfig = new ComponentsConfig();