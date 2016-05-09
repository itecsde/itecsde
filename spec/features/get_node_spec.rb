require 'spec_helper'


array_nodes_1 = ["NT_1_1830","NT_1_1614","NT_2_1579","NT_2_355","NT_5_198","NT_5_7138","NT_4_8413","NT_3_1289"]

array_nodes_2 = ["NT_4_6406","NT_3_5618", "NT_5_5312","NT_3_7366", "NT_3_2603", "NT_3_5872", "NT_4_2545", "NT_3_1683"]

array_nodes = array_nodes_1 + array_nodes_2


array_nodes.each do |node|
   
   Capybara.javascript_driver = :webkit
   session = Capybara::Session.new(:webkit)   
   
   feature 'Get Node' do 
      Steps "Checks if returns correct node" do
       When "I want to get a node " + node.to_s do
         node_id = node.gsub("NT_1_","").gsub("NT_2_","").gsub("NT_3_","").gsub("NT_4_","").gsub("NT_5_","").gsub("TT_","").gsub("MT_","").gsub("DM_","")
         puts node_id
         session.visit '/' + node_id.to_s
         uri = URI.parse(current_url)
         puts uri
       end
       Then "Database must have this node" do
         a=Eurovoc.new
         puts node
         name = a.get_node(node).name
         puts name
         puts session
         expect(session).to have_content(name)
       end
     end
   end
end