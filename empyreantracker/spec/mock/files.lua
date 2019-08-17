local files = {}
function files.new(path, create) end
function files.create(f) end
function files.exists(f) end
function files.check(...) end
function files.read(f) end
function files.create_path(f) end
function files.readlines(f) end
function files.it(f) end
function files.write(f, content, flush) end
function files.append(f, content, flush) end
return files
