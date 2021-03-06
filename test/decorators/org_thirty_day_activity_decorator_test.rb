require 'test_helper'

class OrgThrityDayActivityDecoratorTest < ActiveSupport::TestCase
  describe 'project_count_text' do
    it 'should return "S" for small orgs' do
      ota = create(:org_thirty_day_activity).decorate
      stub_orgs_projects_count(10)
      ota.project_count_text.must_equal 'S'
    end

    it 'should return "M" for medium orgs' do
      ota = create(:org_thirty_day_activity).decorate
      stub_orgs_projects_count(20)
      ota.project_count_text.must_equal 'M'
    end

    it 'should return "L" for large orgs' do
      ota = create(:org_thirty_day_activity).decorate
      stub_orgs_projects_count(55)
      ota.project_count_text.must_equal 'L'
    end

    it 'should return "N/A" with no projects' do
      ota = create(:org_thirty_day_activity).decorate
      stub_orgs_projects_count
      ota.project_count_text.must_equal 'N/A'
    end
  end

  private

  def stub_orgs_projects_count(count = 0)
    Organization.any_instance.stubs(:projects_count).returns(count)
  end
end
