require 'test_helper'

describe 'HelpfulsControllerTest' do
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:linux_review) { project.reviews.create!(title: 'T', comment: 'C', account: admin) }

  it 'test login required' do
    login_as nil
    create_helpful(true)
    must_respond_with :unauthorized
  end

  it 'must create helpful record when user clicks yes' do
    login_as create(:account)
    assert_difference 'Helpful.count' do
      create_helpful(true)
      assigns(:helpful).yes.must_equal true
      must_respond_with :success
      must_render_template 'reviews/_helpful_yes_or_no_links'
    end
  end

  it 'must create helpful record when user clicks no' do
    login_as create(:account)
    assert_difference 'Helpful.count' do
      create_helpful(false)
      assigns(:helpful).yes.must_equal false
      must_respond_with :success
      must_render_template 'reviews/_helpful_yes_or_no_links'
    end
  end

  it 'must update helpful record when it already exists' do
    account = create(:account)
    Helpful.create(review: linux_review, account: account, yes: false)
    login_as account
    assert_no_difference 'Helpful.count' do
      create_helpful(true)
      must_respond_with :success
      assigns(:helpful).yes.must_equal true
    end
  end

  it 'must not allow review creator to vote' do
    login_as admin
    assert_no_difference 'Helpful.count' do
      create_helpful(true)
      must_respond_with :failure
    end
  end

  it 'test review must match project' do
    account = create(:account)
    login_as account
    xhr :post, :create, helpful: { account_id: account, review_id: linux_review },
                        review_id: linux_review.id, project_id: create(:project).to_param, yes: true
    must_respond_with :not_found
  end

  private

  def create_helpful(helpful)
    account = @controller.send(:current_user).id
    xhr :post, :create, helpful: { account_id: account, review_id: linux_review },
                  review_id: linux_review.id, project_id: project.to_param, yes: helpful
  end
end
