require  File.dirname(__FILE__) + '/mingle/mingle-api'

%w{ mingle ticket project comment }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
