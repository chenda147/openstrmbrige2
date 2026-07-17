import { getApiBaseUrl } from '../../shared/config/runtimeConfig'
import type { PaginatedResponse, TaskItem, TaskLogResult, TaskRunResult } from '../../shared/types/domain'

export interface TaskListOptions {
  page?: number
  pageSize?: number
}

export interface TaskService {
  list(options?: TaskListOptions): Promise<PaginatedResponse<TaskItem>>
  save(task: TaskItem): Promise<TaskItem>
  remove(taskId: string): Promise<void>
  run(taskId: string): Promise<TaskRunResponse>
  runAll(): Promise<TaskRunAllResponse>
  stop(taskId: string): Promise<TaskItem>
  getLog(taskId: string): Promise<TaskLogResult>
}

export interface TaskRunResponse {
  task: TaskItem
  result: TaskRunResult
}

export interface TaskRunAllResponse {
  tasks: TaskItem[]
  results: Array<TaskRunResponse | { task: TaskItem; error: string }>
}

const backendBaseUrl = getApiBaseUrl()
const tasksUrl = `${backendBaseUrl}/api/tasks`

async function readJsonResponse<T>(response: Response) {
  const payload = (await response.json()) as T | { message?: string }

  if (!response.ok) {
    const message =
      typeof payload === 'object' && payload !== null && 'message' in payload
        ? payload.message
        : undefined

    throw new Error(message || `HTTP ${response.status}`)
  }

  return payload as T
}

export const taskService: TaskService = {
  async list(options) {
    if (import.meta.env.MODE === 'test') {
      return { items: [], total: 0, page: 1, pageSize: 50 }
    }

    const page = options?.page ?? 1
    const pageSize = options?.pageSize ?? 50
    const response = await fetch(`${tasksUrl}?page=${page}&pageSize=${pageSize}`)
    return readJsonResponse<PaginatedResponse<TaskItem>>(response)
  },
  async save(task) {
    const response = await fetch(`${tasksUrl}/${encodeURIComponent(task.id)}`, {
      body: JSON.stringify(task),
      headers: {
        'Content-Type': 'application/json',
      },
      method: 'PUT',
    })

    return readJsonResponse<TaskItem>(response)
  },
  async remove(taskId) {
    const response = await fetch(`${tasksUrl}/${encodeURIComponent(taskId)}`, {
      method: 'DELETE',
    })

    await readJsonResponse<{ ok: boolean; deleted: boolean }>(response)
  },
  async run(taskId) {
    const response = await fetch(`${tasksUrl}/${encodeURIComponent(taskId)}/run`, {
      method: 'POST',
    })

    return readJsonResponse<TaskRunResponse>(response)
  },
  async runAll() {
    const response = await fetch(`${tasksUrl}/run-all`, {
      method: 'POST',
    })

    return readJsonResponse<TaskRunAllResponse>(response)
  },
  async stop(taskId) {
    const response = await fetch(`${tasksUrl}/${encodeURIComponent(taskId)}/stop`, {
      method: 'POST',
    })

    return readJsonResponse<TaskItem>(response)
  },
  async getLog(taskId) {
    const response = await fetch(`${tasksUrl}/${encodeURIComponent(taskId)}/log`)
    return readJsonResponse<TaskLogResult>(response)
  },
}
