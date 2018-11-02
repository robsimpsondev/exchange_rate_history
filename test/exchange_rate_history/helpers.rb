# Temporarily redirects STDOUT and STDERR to /dev/null
# but does print exceptions should they occur.
# https://gist.github.com/moertel/11091573
def suppress_output
  original_stdout, original_stderr = $stdout.clone, $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end