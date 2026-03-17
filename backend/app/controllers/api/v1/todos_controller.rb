module Api
  module V1
    class TodosController < ApplicationController
      before_action :authenticate_user!
      before_action :set_todo, only: %i[update destroy]

      def index
        render json: {
          todos: current_user.todos.order(created_at: :desc).map { |todo| todo_payload(todo) }
        }, status: :ok
      end

      def create
        todo = current_user.todos.new(todo_params)

        if todo.save
          render json: { todo: todo_payload(todo) }, status: :created
        else
          render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @todo.update(todo_params)
          render json: { todo: todo_payload(@todo) }, status: :ok
        else
          render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @todo.destroy!
        head :no_content
      end

      private

      def set_todo
        @todo = current_user.todos.find(params[:id])
      end

      def todo_params
        params.require(:todo).permit(:title, :completed)
      end

      def todo_payload(todo)
        {
          id: todo.id,
          title: todo.title,
          completed: todo.completed,
          created_at: todo.created_at.iso8601,
          updated_at: todo.updated_at.iso8601
        }
      end
    end
  end
end
