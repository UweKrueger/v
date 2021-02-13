module main

import rand
import time
import vweb
import vweb.sse

struct App {
	vweb.Context
}

fn main() {
	vweb.run<App>(8081)
}

pub fn (mut app App) init_once() {
	app.serve_static('/favicon.ico', 'favicon.ico', 'img/x-icon')
	app.handle_static('.')
}

pub fn (mut app App) index() vweb.Result {
	title := 'SSE Example'
	return $vweb.html()
}

fn (mut app App) sse() vweb.Result {
	mut session := sse.new_connection(app.conn)
	// NB: you can setup session.write_timeout and session.headers here
	session.start() or { return app.server_error(501) }
	session.send_message(data: 'ok') or { return app.server_error(501) }
	for {
		data := '{"time": "$time.now().str()", "random_id": "$rand.ulid()"}'
		session.send_message(event: 'ping', data: data) or { return app.server_error(501) }
		println('> sent event: $data')
		time.sleep_ms(1000)
	}
	return app.server_error(501)
}
