require 'spec_helper'

describe "products/_form" do
  before(:each) do
    @product = assign(:product, stub_model(Product))
  end

  it "renders the form product form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", product_path(@product), "post" do
    end
  end
end
