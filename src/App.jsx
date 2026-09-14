import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import ReactMarkdown from 'react-markdown'
import {
  AppWindow, BookOpen, Download, Edit3, History, LogIn, LogOut,
  Plus, RotateCcw, Save, Upload, UserRound, WifiOff, X
} from 'lucide-react'
import { cloudConfigured, supabase } from './lib/supabase'
import { downloadJson, downloadMarkdown, readMarkdown } from './lib/markdown'
import { getFunctionErrorMessage } from './lib/functionError'
import seed from './data/seed.json'

const DEFAULT_HEADERS = ['核心術語 / 簡稱', '國際生態 / 英文全稱', '國內對標 / 中文名稱', '學術釋義與應用語境']
const FIELDS = ['term', 'intl', 'cn', 'description']

function Modal({ title, children, onClose, wide = false }) {
  return <div className="modal-backdrop" role="presentation" onMouseDown={onClose}>
    <section className={`modal ${wide ? 'modal-wide' : ''}`} role="dialog" aria-modal="true" aria-label={title} onMouseDown={e => e.stopPropagation()}>
      <header className="modal-header"><h2>{title}</h2><button className="icon-button" onClick={onClose} aria-label="关闭"><X /></button></header>
      {children}
    </section>
  </div>
}

function Toast({ toast }) {
  if (!toast) return null
  return <div className={`toast ${toast.type || ''}`}>{toast.message}</div>
}

function EditableCell({ value, disabled, lockedBy, multiline, onStart, onCancel, onCommit }) {
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(value || '')
  const ref = useRef(null)
  useEffect(() => { if (!editing) setDraft(value || '') }, [value, editing])
  useEffect(() => { if (editing) ref.current?.focus() }, [editing])

  const begin = () => {
    if (disabled || lockedBy) return
    setDraft(value || '')
    setEditing(true)
    onStart?.()
  }
  const finish = async () => {
    setEditing(false)
    onCancel?.()
    if (draft !== (value || '')) await onCommit(draft)
  }
  if (editing) {
    const props = {
      ref, value: draft, onChange: e => setDraft(e.target.value), onBlur: finish,
      onKeyDown: e => {
        if (e.key === 'Escape') { setDraft(value || ''); setEditing(false); onCancel?.() }
        if (e.key === 'Enter' && (!multiline || !e.shiftKey)) { e.preventDefault(); ref.current?.blur() }
      }
    }
    return multiline ? <textarea className="cell-input multiline" {...props} /> : <input className="cell-input" {...props} />
  }
  return <button className="cell-display" disabled={disabled || Boolean(lockedBy)} onClick={begin} title={lockedBy ? `${lockedBy} 正在编辑` : ''}>
    <span className={value ? '' : 'placeholder'}>{value || '点击编辑…'}</span>
    {lockedBy ? <small>{lockedBy} 正在编辑</small> : !disabled && <Edit3 />}
  </button>
}

function AuthModal({ onClose, onAuthenticated, notify }) {
  const [mode, setMode] = useState('login')
  const [busy, setBusy] = useState(false)
  const [form, setForm] = useState({ username: '', displayName: '', email: '', password: '', inviteCode: '' })
  const update = e => setForm(v => ({ ...v, [e.target.name]: e.target.value }))
  const submit = async e => {
    e.preventDefault(); setBusy(true)
    try {
      if (mode === 'login' && form.email.trim()) {
        const { error } = await supabase.auth.signInWithPassword({
          email: form.email.trim().toLowerCase(),
          password: form.password
        })
        if (error) throw error
        await onAuthenticated(); onClose(); return
      }
      const { data, error } = await supabase.functions.invoke(mode === 'login' ? 'username-login' : 'register', { body: form })
      if (error || data?.error) throw new Error(await getFunctionErrorMessage(error, data))
      if (mode === 'login') {
        const { error: sessionError } = await supabase.auth.setSession({ access_token: data.access_token, refresh_token: data.refresh_token })
        if (sessionError) throw sessionError
      } else {
        notify('注册成功，请登录')
        setMode('login'); setBusy(false); return
      }
      await onAuthenticated(); onClose()
    } catch (error) { notify(error.message, 'error') } finally { setBusy(false) }
  }
  const recover = async () => {
    if (!form.email) return notify('请先填写恢复邮箱', 'error')
    const { error } = await supabase.auth.resetPasswordForEmail(form.email, { redirectTo: window.location.origin })
    notify(error ? error.message : '密码恢复邮件已发送', error ? 'error' : 'success')
  }
  return <Modal title={mode === 'login' ? '成员登录' : '成员注册'} onClose={onClose}>
    <form className="form-stack" onSubmit={submit}>
      <label>{mode === 'login' ? '用户名（不是实名或邮箱）' : '用户名'}<input required name="username" autoComplete="username" value={form.username} onChange={update} /></label>
      {mode === 'register' && <>
        <label>实名显示名<input required name="displayName" value={form.displayName} onChange={update} /></label>
        <label>恢复邮箱<input required type="email" name="email" value={form.email} onChange={update} /></label>
        <label>邀请码<input required name="inviteCode" value={form.inviteCode} onChange={update} /></label>
      </>}
      {mode === 'login' && <label>邮箱（可直接登录，也用于找回密码）<input type="email" name="email" value={form.email} onChange={update} /></label>}
      <label>密码<input required minLength="8" type="password" name="password" autoComplete={mode === 'login' ? 'current-password' : 'new-password'} value={form.password} onChange={update} /></label>
      <button className="primary" disabled={busy}>{busy ? '请稍候…' : mode === 'login' ? '登录' : '注册'}</button>
      <div className="form-actions"><button type="button" onClick={() => setMode(mode === 'login' ? 'register' : 'login')}>{mode === 'login' ? '使用邀请码注册' : '已有账号，返回登录'}</button>{mode === 'login' && <button type="button" onClick={recover}>忘记密码</button>}</div>
    </form>
  </Modal>
}

function ResetPasswordModal({ onClose, notify }) {
  const [password, setPassword] = useState('')
  const submit = async e => {
    e.preventDefault()
    const { error } = await supabase.auth.updateUser({ password })
    notify(error ? error.message : '密码已更新', error ? 'error' : 'success')
    if (!error) onClose()
  }
  return <Modal title="设置新密码" onClose={onClose}><form className="form-stack" onSubmit={submit}><label>新密码<input type="password" minLength="8" required value={password} onChange={e => setPassword(e.target.value)} /></label><button className="primary">更新密码</button></form></Modal>
}

function NoteModal({ entry, canEdit, notify, onClose }) {
  const [note, setNote] = useState({ note: '', prompt: '', skill_urls: [], markdown: '' })
  const [tab, setTab] = useState('edit')
  const [busy, setBusy] = useState(true)
  useEffect(() => {
    supabase.from('entry_notes').select('note,prompt,skill_urls,markdown').eq('entry_id', entry.id).maybeSingle()
      .then(({ data, error }) => { if (error) notify(error.message, 'error'); if (data) setNote(data); setBusy(false) })
  }, [entry.id, notify])
  const save = async () => {
    setBusy(true)
    const { error } = await supabase.from('entry_notes').upsert({ entry_id: entry.id, ...note })
    notify(error ? error.message : '详细笔记已保存', error ? 'error' : 'success'); setBusy(false)
  }
  const importMd = async e => {
    try {
      const markdown = await readMarkdown(e.target.files?.[0])
      setNote(v => ({ ...v, markdown }))
    } catch (error) { notify(error.message, 'error') }
    e.target.value = ''
  }
  return <Modal title={`详细笔记 · ${entry.term || '未命名条目'}`} onClose={onClose} wide>
    {busy && !note.markdown ? <p className="empty">载入中…</p> : <div className="note-layout">
      <label>补充笔记<textarea disabled={!canEdit} value={note.note || ''} onChange={e => setNote(v => ({ ...v, note: e.target.value }))} /></label>
      <label>提示词<textarea disabled={!canEdit} value={note.prompt || ''} onChange={e => setNote(v => ({ ...v, prompt: e.target.value }))} /></label>
      <label>Skill.md 链接（每行一个）<textarea disabled={!canEdit} value={(note.skill_urls || []).join('\n')} onChange={e => setNote(v => ({ ...v, skill_urls: e.target.value.split('\n').map(x => x.trim()).filter(Boolean) }))} /></label>
      <div className="markdown-toolbar"><div><button className={tab === 'edit' ? 'active' : ''} onClick={() => setTab('edit')}>编辑</button><button className={tab === 'preview' ? 'active' : ''} onClick={() => setTab('preview')}>预览</button></div><div><label className="file-button"><Upload /> 导入<input type="file" accept=".md,text/markdown" onChange={importMd} /></label><button onClick={() => downloadMarkdown(entry.term, note.markdown)}><Download /> 下载</button></div></div>
      {tab === 'edit' ? <textarea className="markdown-editor" disabled={!canEdit} value={note.markdown || ''} onChange={e => setNote(v => ({ ...v, markdown: e.target.value }))} /> : <article className="markdown-preview"><ReactMarkdown>{note.markdown || '*暂无 Markdown 内容*'}</ReactMarkdown></article>}
      {canEdit && <button className="primary" disabled={busy} onClick={save}><Save /> 保存详细笔记</button>}
    </div>}
  </Modal>
}

function HistoryModal({ profile, notify, onClose, onRestored }) {
  const [history, setHistory] = useState([])
  const [snapshots, setSnapshots] = useState([])
  const [name, setName] = useState('')
  const load = useCallback(async () => {
    const [h, s] = await Promise.all([
      supabase.from('change_history').select('id,action,entity_type,field_name,created_at,actor_name').order('created_at', { ascending: false }).limit(100),
      supabase.from('snapshots').select('id,name,description,created_at,creator_name').order('created_at', { ascending: false })
    ])
    if (h.error || s.error) notify((h.error || s.error).message, 'error')
    setHistory(h.data || []); setSnapshots(s.data || [])
  }, [notify])
  useEffect(() => { load() }, [load])
  const createSnapshot = async () => {
    const { error } = await supabase.rpc('create_snapshot', { snapshot_name: name || '手动快照', snapshot_description: '' })
    notify(error ? error.message : '快照已创建', error ? 'error' : 'success'); if (!error) { setName(''); load() }
  }
  const restore = async id => {
    if (!window.confirm('恢复会改变当前内容，但不会删除历史。确认继续？')) return
    const { error } = await supabase.rpc('restore_snapshot', { target_snapshot_id: id })
    notify(error ? error.message : '版本已恢复', error ? 'error' : 'success'); if (!error) { await onRestored(); load() }
  }
  return <Modal title="版本与修改历史" onClose={onClose} wide>
    <div className="history-grid">
      <section><h3>命名快照</h3><div className="snapshot-create"><input placeholder="例如：课程发布版" value={name} onChange={e => setName(e.target.value)} /><button className="primary" onClick={createSnapshot}>创建快照</button></div>
        <div className="history-list">{snapshots.map(s => <div key={s.id}><div><strong>{s.name}</strong><small>{s.creator_name} · {new Date(s.created_at).toLocaleString()}</small></div>{profile?.role === 'admin' && <button onClick={() => restore(s.id)}><RotateCcw />恢复</button>}</div>)}</div>
      </section>
      <section><h3>最近修改</h3><div className="history-list">{history.map(h => <div key={h.id}><div><strong>{h.actor_name || '系统'} · {h.action}</strong><small>{h.entity_type}{h.field_name ? ` / ${h.field_name}` : ''} · {new Date(h.created_at).toLocaleString()}</small></div></div>)}</div></section>
    </div>
  </Modal>
}

export default function App() {
  const [categories, setCategories] = useState([])
  const [entries, setEntries] = useState([])
  const [session, setSession] = useState(null)
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [online, setOnline] = useState(navigator.onLine)
  const [toast, setToast] = useState(null)
  const [modal, setModal] = useState(null)
  const [locks, setLocks] = useState({})
  const [installPrompt, setInstallPrompt] = useState(null)
  const channelRef = useRef(null)
  const importRef = useRef(null)
  const notify = useCallback((message, type = 'success') => { setToast({ message, type }); window.setTimeout(() => setToast(null), 3200) }, [])
  const editable = Boolean(session && online && cloudConfigured)

  const loadProfile = useCallback(async currentSession => {
    if (!currentSession) { setProfile(null); return }
    const { data } = await supabase.from('profiles').select('id,username,display_name,role').eq('id', currentSession.user.id).single()
    setProfile(data || null)
  }, [])
  const loadContent = useCallback(async () => {
    if (!cloudConfigured || !online) { setCategories(seed.categories); setEntries(seed.entries); setLoading(false); return }
    const [c, e] = await Promise.all([
      supabase.from('categories').select('*').is('deleted_at', null).order('sort_order'),
      supabase.from('entries').select('*').is('deleted_at', null).order('sort_order')
    ])
    if (c.error || e.error) notify((c.error || e.error).message, 'error')
    else { setCategories(c.data || []); setEntries(e.data || []) }
    setLoading(false)
  }, [online, notify])

  useEffect(() => {
    const up = () => { setOnline(true); notify('网络已恢复') }
    const down = () => { setOnline(false); setCategories([]); setEntries([]); notify('当前离线，编辑已停用', 'error') }
    window.addEventListener('online', up); window.addEventListener('offline', down)
    const install = e => { e.preventDefault(); setInstallPrompt(e) }
    window.addEventListener('beforeinstallprompt', install)
    return () => { window.removeEventListener('online', up); window.removeEventListener('offline', down); window.removeEventListener('beforeinstallprompt', install) }
  }, [notify])
  useEffect(() => {
    if (!cloudConfigured) { loadContent(); return }
    supabase.auth.getSession().then(({ data }) => { setSession(data.session); loadProfile(data.session) })
    const { data } = supabase.auth.onAuthStateChange((event, next) => { setSession(next); loadProfile(next); if (event === 'PASSWORD_RECOVERY') setModal({ type: 'reset' }) })
    return () => data.subscription.unsubscribe()
  }, [loadContent, loadProfile])
  useEffect(() => { loadContent() }, [loadContent, session])
  useEffect(() => {
    if (!cloudConfigured || !online) return
    const db = supabase.channel('content-updates').on('postgres_changes', { event: '*', schema: 'public', table: 'categories' }, loadContent).on('postgres_changes', { event: '*', schema: 'public', table: 'entries' }, loadContent).subscribe()
    return () => { supabase.removeChannel(db) }
  }, [online, loadContent])
  useEffect(() => {
    if (!profile || !online) return
    const channel = supabase.channel('workspace:main', { config: { private: true, presence: { key: profile.id } } })
    channel.on('presence', { event: 'sync' }, () => {
      const state = channel.presenceState(); const next = {}
      Object.values(state).flat().forEach(p => { if (p.editing && p.userId !== profile.id) next[p.editing] = p.displayName })
      setLocks(next)
    }).subscribe(async status => { if (status === 'SUBSCRIBED') await channel.track({ userId: profile.id, displayName: profile.display_name, editing: null }) })
    channelRef.current = channel
    return () => { channelRef.current = null; supabase.removeChannel(channel) }
  }, [profile, online])

  const trackLock = editing => channelRef.current?.track({ userId: profile.id, displayName: profile.display_name, editing })
  const updateEntry = async (entry, field, value) => {
    const { data, error } = await supabase.rpc('update_entry_field', { target_id: entry.id, target_field: field, new_value: value, expected_revision: entry.revision })
    if (error) { notify(error.message.includes('revision') ? '内容已被其他成员修改，请查看最新版后重试' : error.message, 'error'); await loadContent() }
    else setEntries(list => list.map(x => x.id === entry.id ? data : x))
  }
  const updateCategory = async (category, patch) => {
    const { error } = await supabase.from('categories').update(patch).eq('id', category.id).eq('revision', category.revision)
    notify(error ? error.message : '已保存', error ? 'error' : 'success'); await loadContent()
  }
  const addCategory = async () => {
    const { error } = await supabase.from('categories').insert({ title: '新研究模块', headers: DEFAULT_HEADERS, sort_order: categories.length })
    if (error) notify(error.message, 'error')
  }
  const addEntry = async category => {
    const { error } = await supabase.from('entries').insert({ category_id: category.id, term: '', intl: '-', cn: '-', description: '', sort_order: entries.filter(x => x.category_id === category.id).length })
    if (error) notify(error.message, 'error')
  }
  const removeEntry = async entry => {
    if (!window.confirm(`删除“${entry.term || '未命名条目'}”？可通过版本历史恢复。`)) return
    const { error } = await supabase.from('entries').update({ deleted_at: new Date().toISOString() }).eq('id', entry.id)
    if (error) notify(error.message, 'error')
  }
  const grouped = useMemo(() => categories.map(c => ({ ...c, entries: entries.filter(e => e.category_id === c.id) })), [categories, entries])

  const exportJson = () => downloadJson(`pixplory-backup-${new Date().toISOString().slice(0, 10)}`, { version: 2, categories, entries })
  const importJson = async event => {
    try {
      const file = event.target.files?.[0]
      if (!file) return
      const payload = JSON.parse(await file.text())
      const { error } = await supabase.rpc('import_workspace', { import_state: payload })
      if (error) throw error
      notify('导入完成，已自动保留导入前快照'); await loadContent()
    } catch (error) { notify(`导入失败：${error.message}`, 'error') }
    event.target.value = ''
  }
  const install = async () => { if (installPrompt) { await installPrompt.prompt(); setInstallPrompt(null) } else notify('请使用浏览器菜单中的“安装应用”或“添加到程序坞”') }
  const logout = async () => { await supabase.auth.signOut(); setSession(null); setProfile(null) }

  return <div className="app-shell">
    <Toast toast={toast} />
    <div className="ambient" />
    <main>
      <header className="hero">
        <div><p className="eyebrow">PIXPLORY · DIGITAL MEDIA ART TAXONOMY</p><h1>AI 全棧創作索引</h1><p className="subtitle">运用 AI 智能体实现跨界融合的“全栈型创作者”</p><div className="status-row">{!online ? <span className="status danger"><WifiOff />离线，只读数据已隐藏</span> : !cloudConfigured ? <span className="status warning">尚未配置 Supabase · 当前显示迁移预览</span> : <span className="status">云端实时同步</span>}{profile && <span className="member"><UserRound />{profile.display_name} · {profile.role === 'admin' ? '管理员' : '成员'}</span>}</div></div>
        <div className="toolbar">
          <button onClick={install}><AppWindow />安装桌面版</button>
          {session && <button onClick={() => setModal({ type: 'history' })}><History />版本历史</button>}
          {profile?.role === 'admin' && <><button onClick={exportJson}><Download />备份</button><input ref={importRef} hidden type="file" accept=".json,application/json" onChange={importJson} /><button onClick={() => importRef.current?.click()}><Upload />导入</button></>}
          {!session ? <button className="primary" disabled={!cloudConfigured} onClick={() => setModal({ type: 'auth' })}><LogIn />成员登录</button> : <button onClick={logout}><LogOut />退出</button>}
          {editable && <button className="primary" onClick={addCategory}><Plus />新增模块</button>}
        </div>
      </header>

      {loading ? <p className="empty">正在读取最新内容…</p> : !online ? <div className="offline-panel"><WifiOff /><h2>当前没有网络连接</h2><p>为避免展示过期内容或产生冲突，业务数据已隐藏，恢复联网后会自动加载最新版。</p></div> : <div className="category-list">
        {grouped.map(category => <section className="category" key={category.id}>
          <div className="category-title"><EditableCell value={category.title} disabled={!editable} lockedBy={locks[`category:${category.id}:title`]} onStart={() => trackLock(`category:${category.id}:title`)} onCancel={() => trackLock(null)} onCommit={value => updateCategory(category, { title: value })} />{editable && <button onClick={() => addEntry(category)}><Plus />添加条目</button>}</div>
          <div className="table-wrap"><table><thead><tr>{(category.headers || DEFAULT_HEADERS).map((header, i) => <th key={i}><EditableCell value={header} disabled={!editable} lockedBy={locks[`category:${category.id}:header:${i}`]} onStart={() => trackLock(`category:${category.id}:header:${i}`)} onCancel={() => trackLock(null)} onCommit={value => { const headers = [...(category.headers || DEFAULT_HEADERS)]; headers[i] = value; return updateCategory(category, { headers }) }} /></th>)}<th>操作</th></tr></thead>
            <tbody>{category.entries.map(entry => <tr key={entry.id}>{FIELDS.map(field => <td key={field}><EditableCell value={entry[field]} multiline={field === 'description'} disabled={!editable} lockedBy={locks[`entry:${entry.id}:${field}`]} onStart={() => trackLock(`entry:${entry.id}:${field}`)} onCancel={() => trackLock(null)} onCommit={value => updateEntry(entry, field, value)} /></td>)}<td className="row-actions">{session && <button title="详细笔记" onClick={() => setModal({ type: 'note', entry })}><BookOpen /></button>}{editable && <button className="danger-button" title="删除" onClick={() => removeEntry(entry)}><X /></button>} {session && <small>{entry.last_editor_name ? `${entry.last_editor_name} · ` : ''}{entry.updated_at ? new Date(entry.updated_at).toLocaleDateString() : ''}</small>}</td></tr>)}</tbody>
          </table></div>
        </section>)}
      </div>}
    </main>
    <footer>PIXPLORY · 云端内容为唯一正式版本</footer>
    {modal?.type === 'auth' && <AuthModal onClose={() => setModal(null)} onAuthenticated={async () => { const { data } = await supabase.auth.getSession(); setSession(data.session); await loadProfile(data.session) }} notify={notify} />}
    {modal?.type === 'reset' && <ResetPasswordModal onClose={() => setModal(null)} notify={notify} />}
    {modal?.type === 'note' && <NoteModal entry={modal.entry} canEdit={editable} notify={notify} onClose={() => setModal(null)} />}
    {modal?.type === 'history' && <HistoryModal profile={profile} notify={notify} onClose={() => setModal(null)} onRestored={loadContent} />}
  </div>
}
