class MessagesController < ApplicationController
  include ActionController::Live
  
  #respond_to :js, :html
  def new
    @message = Message.new
  end

  def create
    @task = Task.find(params[:message][:task_id])
    @message = @task.messages.create(messages_params)

    teacher = @task.job.assignment.term.course.teacher
    student = @task.student.user
    if teacher.id == @message.user_id
      addressee = student
    else
      addressee = teacher
    end
    Notification.new_event(user: addressee, task: @task, event_type: :added_message, event_time: @message.created_at)
  end

  def events 
    response.headers["Content-Type"] = "text/event-stream"
    start = Time.zone.now
    10.times do
      Message.uncached do
        Message.where('created_at > ?', start).each do |message|
          response.stream.write "data: #{message.to_json}\n\n"
          start = message.created_at
        end
      end
      sleep 2
    end
  rescue IOError
    logger.info "Stream closed"
  ensure
    response.stream.close
  end

  private
  def messages_params
    params.require(:message).permit(:text, :user_id, :task_id)
  end
end
