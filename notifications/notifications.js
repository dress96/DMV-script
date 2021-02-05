$(function(){
	window.onload = (e) => {

        $("#main-notificacions").hide();

		window.addEventListener('message', (event) => {

			var item = event.data;
			if (item !== undefined && item.type === "ui") {
				if (item.display === true) {
                    $("#main-notificacions").show();
                     
				} else{
                    $("#main-notificacions").hide();
                }
			}
		});
	};
});