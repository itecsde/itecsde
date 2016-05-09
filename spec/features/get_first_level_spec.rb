require 'spec_helper'


array_nodes_1 = ["NT_1_1830","NT_1_1614","NT_2_1579","NT_2_355","NT_5_198","NT_5_7138","NT_4_8413","NT_3_1289"]

array_nodes_2 = ["NT_4_6406","NT_3_5618", "NT_5_5312","NT_3_7366", "NT_3_2603", "NT_3_5872", "NT_4_2545", "NT_3_1683"]

array_nodes = array_nodes_1 + array_nodes_2

array_nodes.each do |node|
   
   Capybara.javascript_driver = :webkit
   session = Capybara::Session.new(:webkit)   
   
   feature 'Get First Level' do 
      Steps "Checks if returns correct first level node" do
       When "I want to get the first level of the node " + node.to_s do
         node_id = node.gsub("NT_1_","").gsub("NT_2_","").gsub("NT_3_","").gsub("NT_4_","").gsub("NT_5_","").gsub("TT_","").gsub("MT_","").gsub("DM_","")
         puts node_id
         session.visit '/' + node_id.to_s
         uri = URI.parse(current_url)
         puts uri
       end
       Then "the first level obtained has to be the same as in web page" do
         a=Eurovoc.new
         puts node
         first_level = a.get_first_level(node)
         puts first_level
         expect(session).to have_content(first_level)
       end
     end
   end
end