class MessagesController < ApplicationController
  respond_to :js, :html
  def new
    @message = Message.new
  end

  def create
    @task = Task.find(params[:message][:task_id])
    @message = @task.messages.create(messages_params)
  end

  private
  def messages_params
    params.require(:message).permit(:text, :user_id, :task_id)
  end
end
