module Extensions
  def search_for_nodes(query = nil, attribute = nil)
    nodes = find_matching_nodes(query)
    nodes.map do |node|
      select_attribute(node, attribute)
    end
  end

  def find_matching_nodes(query = nil)
    query ||= "roles:namenode AND chef_environment:#{node.chef_environment}"
    results = []
    Chef::Log.debug("Searching for nodes with query: \"#{query}\"")
    Chef::Search::Query.new.search(:node, query) { |o| results << o }
    results
  end

  def select_attribute(node, attribute = nil)
    if attribute
      keys = attribute.split('.')
      value = node
      keys.each do |key|
        value = value[key]
      end
      Chef::Log.debug("Selected attribute: #{attribute.inspect} for node: #{node.name.inspect} with value: #{value.inspect}")
      value
    else
      if node.has_key? 'cloud' and node['cloud'].has_key? 'local_ipv4'
        value = node['cloud']['local_ipv4']
        Chef::Log.debug("Selected attribute: \"cloud.local_ipv4\" for node: #{node.name.inspect} with value: #{value.inspect}")
        value
      else
        value = node['ipaddress']
        Chef::Log.debug("Selected attribute: \"ipaddress\" for node: #{node.name.inspect} with value: #{value.inspect}")
        value
      end
    end
  end
end
