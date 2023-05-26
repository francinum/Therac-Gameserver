Byond.subscribeTo('update_lcd', function (payload) {
	//This is a <pre> tag anyways. Just being safe.
	document.getElementById('lcd_text').innerText = payload.lcdtext
});

function send_keypress(kp_code) {
	Byond.sendMessage('kp_press', {
		button: kp_code
	})
}
