class TodosController < ApplicationController

  def index
    @todos = Todo.all
  end

  # 新規作成画面遷移
  def new
    @todo = Todo.new
  end

  def show
    @todo = Todo.find(params[:id])
  end

  # 新規作成保存
  def create
    todo = Todo.create(todo_params)
    if todo.save
      flash[:notice] = "「#{todo.title}」を作成しました"
      redirect_to todos_path
    else
      # バリデーションに引っかかった場合
      # newに飛ばす
      redirect_to new_todo_path, flash: {
          todo: todo,
          error_messages: todo.errors.full_messages
      }
    end
  end

  def edit
    @todo = Todo.find(params[:id])
  end

  # 編集
  def update
    @todo = Todo.find(params[:id])

    if @todo.update(todo_params)
      flash[:notice] = "「#{@todo.title}」を編集しました"
    else
      flash[:notice_error] = "「#{@todo.title}」の編集に失敗しました"
    end

    redirect_to todo_path
  end

  # 削除
  def destroy
    @todo = Todo.find(params[:id])
    @todo.delete

    flash[:notice] = "「#{@todo.title}」を削除しました"

    redirect_to todos_path
  end


  private
  # フィルター追加
  def todo_params
    params.require(:todo).permit(:title, :content, :status)
  end
end