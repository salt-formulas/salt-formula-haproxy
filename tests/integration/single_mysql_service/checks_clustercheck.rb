describe file('/etc/xinetd.d/mysql_clustercheck_127.0.0.1_3306_9200') do
    it('should exist')
    its('content') { should match /clustercheck clustercheck clustercheck 1 0/ }
end

describe file('/usr/local/bin/mysql_clustercheck') do
    it('should exist')
end
